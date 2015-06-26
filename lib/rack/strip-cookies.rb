module Rack
  class StripCookies
    attr_reader :paths, :exclude

    def initialize(app, options = {})
      @app, @paths, @exclude = app, Array(options[:paths]), Array(options[:exclude])
    end

    def call(env)
      path     = Rack::Request.new(env).path
      included = paths.any? { |s| path.include?(s)}

      need_delete = paths.any? { |s| path.include?(s)}
      need_delete &&= !exclude.any? { |s| path.include?(s)}

      env.delete('HTTP_COOKIE') if need_delete

      status, headers, body = @app.call(env)
      headers.delete('Set-Cookie') if need_delete

      [status, headers, body]
    end
  end
end
