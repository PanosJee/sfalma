begin
  class Delayed::Job
    def log_exception_with_exceptional(e)
      Sfalma.handle(e, "Delayed::Job #{self.name}")
      log_exception_without_exceptional(e)
      Sfalma.context.clear!
    end
    alias_method_chain :log_exception, :sfalma
    Sfalma.logger.info "DJ integration enabled"
  end
rescue
end