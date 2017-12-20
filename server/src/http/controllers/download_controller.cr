require "./controller_base"

module AlexiServer
  module HttpAPI
    module DownloadController
      include AlexiServer::HttpAPI::ControllerBase
      extend self

      def get_download_url(ctx)
        begin
          year = get_param!(ctx, "year").to_i
          day = get_param!(ctx, "day").to_i
          tile = get_param!(ctx, "tile").to_i
          typ = get_param!(ctx, "type")
          user = get_user(ctx)

          raise "Wrong type" unless (typ == "png" || typ == "tif")
          raise "No permission" if (user.nil? && typ == "tif")

          download = Download.create_download(user, year, day, tile, typ)
          download.to_url.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def download_file(ctx)
        begin
          key = get_param!(ctx, "key")
          download = Download.get_download(key)
          path = download.to_file_path
          filename = File.basename(path)
          ctx.response.headers["Content-Disposition"] = "attachment; filename=\"" + filename + "\""
          send_file ctx, path
          return
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
