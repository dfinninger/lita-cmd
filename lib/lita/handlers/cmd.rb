require 'open3'
require 'iconv'

module Lita
  module Handlers
    class Cmd < Handler

      config :scripts_dir

      route(/^\s*cmd-help\s*$/, :cmd_help, command: true, help: {
        "cmd-help" => "get a list of scripts available for execution"
      })

      def cmd_help(resp)
        out = Array.new

        Dir.chdir(config.scripts_dir)
        Dir.glob('*').each { |d| out << d }

        list = out.sort.join("\n")

        resp.reply code_blockify(list)
      end

      route(/^\s*cmd\s+(\S*)\s*(.*)$/, :cmd, command: true, help: {
        "cmd SCRIPT" => "run the SCRIPT specified; use `lita cmd help` for a list"
      })

      def cmd(resp)
        dir = config.scripts_dir
        script = resp.matches[0][0]
        opts = resp.matches[0][1].split(" ")
        Dir.chdir('/tmp')

        out = String.new
        err = String.new
        Open3.popen3("#{dir}/#{script}", *opts) do |i, o, e, wait_thread|
          o.each { |line| out << "[stdout] #{line}" }
          e.each { |line| err << "[stderr] #{line}" }
        end

        if err != String.new
          out << "\n\n#{err}"
        end
        Iconv.conv('ASCII//IGNORE', 'UTF8', out)
        resp.reply code_blockify(out)
      end

      def code_blockify(text)
        "```\n" + text + "\n```"
      end

    end

    Lita.register_handler(Cmd)
  end
end
