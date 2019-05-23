module Noticent
  class Channel

    @@default_ext = :erb
    @@default_format = :html

    def initialize(recipients, payload, context)
      @recipients = recipients
      @payload = payload
      @context = context
      @current_user = payload.current_user if payload.respond_to? :current_user
      @named_content = {}
    end

    def render_within_context(template, content)
      rendered_content = ERB.new(content).result(get_binding)
      template.nil? ? rendered_content : ERB.new(template).result(get_binding { |x| x.nil? ? rendered_content : @named_content[x] })
    end

    def content_for(name)
      @named_content[name] = yield
    end

    protected

    attr_reader :payload
    attr_reader :recipients
    attr_reader :context

    def self.default_format(format)
      @@default_format = format
    end

    def self.default_ext(ext)
      @@default_ext = ext
    end

    def get_binding
      binding
    end

    def current_user
      raise Noticent::NoCurrentUser if @current_user.nil?

      @current_user
    end

    def render(format: @@default_format, ext: @@default_ext, layout: '')
      alert_name = caller[0][/`.*'/][1..-2]
      channel_name = self.class.name.split('::').last.underscore
      view_filename = view_file(channel: channel_name, alert: alert_name, format: format, ext: ext)
      layout_filename = ''
      layout_filename = File.join(Noticent.view_dir, 'layouts', "#{layout}.#{format}.#{ext}") unless layout == ''

      raise Noticent::ViewNotFound, "view #{view_filename} not found" unless File.exist?(view_filename)

      view = View.new(view_filename, template_filename: layout_filename, channel: self)
      view.process

      return view.data, view.content
    end

    private

    def view_file(channel:, alert:, format:, ext: )
      File.join(Noticent.view_dir, channel, "#{alert}.#{format}.#{ext}")
    end

  end
end