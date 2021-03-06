# frozen_string_literal: true

module Noticent
  class ProcMap
    def initialize(config)
      @map = {}
      @config = config
    end

    def use(symbol, proc)
      raise Noticent::BadConfiguration, 'should provide a proc' unless proc.is_a?(Proc)
      raise Noticent::BadConfiguration, "invalid number of parameters for 'use' in '#{symbol}'" if proc.arity != 1

      @map[symbol] = proc
    end

    def fetch(symbol)
      raise Noticent::Error, "no map found for '#{symbol}'" if @map[symbol].nil?

      @map[symbol]
    end

    def count
      @map.count
    end

    def values
      @map
    end

    protected

    attr_reader :config
  end
end
