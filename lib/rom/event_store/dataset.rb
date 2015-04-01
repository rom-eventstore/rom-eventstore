module ROM
  module EventStore
    class Dataset
      attr_reader :name

      def initialize(name, connection, options = {})
        @name = name
        @connection = connection
        @options = options
      end

      def from_stream(id)
        __new__(stream: id)
      end

      def stream
        stream = @options[:stream]
        stream ? "#{name}-#{stream}" : "$#{name}"
      end

      def events
        @connection.read(stream, option(:start, 0), option(:limit, 20))
      end

      def append(events)
        @connection.append(stream, events)
      end

      def each
        if block_given?
          events.each { |event| yield(event) }
        else
          to_enum
        end
      end

      private

      def __new__(new_opts = {})
        self.class.new(@name, @connection, @options.merge(new_opts))
      end

      def option(option, default)
        @options.fetch(option, default)
      end
    end
  end
end
