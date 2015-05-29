require 'open3'

module Lita
  module Handlers
    class Cmd < Handler

      config :scripts_dir

      ### CMD-HELP ##############################################

      route(/^\s*cmd-help\s*$/, :cmd_help, command: true, help: {
        "cmd-help" => "get a list of scripts available for execution"
      })

      def cmd_help(resp)
        list = Dir.entries(config.scripts_dir).select { |f| File.file? "#{config.scripts_dir}/#{f}" }

        out = list.sort.join("\n")
        resp.reply_privately code_blockify(out)
      end

      ### CMD ###################################################

      route(/^\s*cmd\s+(\S*)\s*(.*)$/, :cmd, command: true, help: {
        "cmd SCRIPT" => "run the SCRIPT specified; use `lita cmd help` for a list"
      })

      def cmd(resp)
        script = resp.matches[0][0]
        opts = resp.matches[0][1].split(" ")

        out = String.new
        err = String.new
        Open3.popen3("#{config.scripts_dir}/#{script}", *opts) do |i, o, e, wait_thread|
          o.each { |line| out << "[stdout] #{line}" }
          e.each { |line| err << "[stderr] #{line}" }
        end

        if err != String.new
          out << "\n\n#{err}"
        end

        # Scrub Unicode to ASCII
        encoding_options = {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => ''        # Use a blank for those replacements
        }
        ascii_out = out.encode(Encoding.find('ASCII'), encoding_options)

        ascii_out.split("\n").each_slice(50) do |slice|
          resp.reply code_blockify(slice.join("\n"))
        end
      end

      ### HELPERS ############################################

      private
      def code_blockify(text)
        "```\n#{text}\n```"
      end

    end

    Lita.register_handler(Cmd)
  end
end
