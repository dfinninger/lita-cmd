require 'open3'

module Lita
  module Handlers
    class Cmd < Handler

      config :scripts_dir

      route(/^\s*cmd-help\s*$/, command: true, help: {
        "cmd-help" => "get a list of scripts available for execution"
      }) do |resp|
        Dir.chdir(config.scripts_dir)
        out = String.new
        Dir.glob('*').each { |d| out << d }
        resp.reply code_blockify(out)
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
          o.each { |line| out << "[#{script} :: stdout] #{line}" }
          e.each { |line| err << "[#{script} :: stderr] #{line}" }
        end

        if err != String.new
          out << "\n\n#{err}"
        end
        resp.reply code_blockify(out)
      end

      def code_blockify(text)
        "```\n" + text + "\n```"
      end

    end

    Lita.register_handler(Cmd)
  end
end
