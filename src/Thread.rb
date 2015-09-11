class << Thread
  alias_method :original_new, :new

  def Thread.new(*args, &block)
    if Thread.main[:max_concurrent] and Thread.main[:max_concurrent] > 0 then
      while(Thread.list.size >= Thread.main[:max_concurrent]) do
        Thread.pass
      end
    end
    printf "."
    Thread.original_new(args,&block)
  end

  def Thread.max_concurrent=(num = 10)
    Thread.main[:max_concurrent] = num
  end
end
