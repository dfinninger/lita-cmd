require 'open3'
require 'csv'

module Lita
  module Handlers
    class Cmd < Handler

      config :scripts_dir

      ### CMD-HELP ##############################################

      route(/^\s*cmd-help\s*$/, :cmd_help, command: true, help: {
        "cmd-help" => "get a list of scripts available for execution"
      })

      route(/^\s*test\s*/) do |resp|
        auth = Lita::Robot.new.auth
        resp.reply "true" if auth.groups_with_users[:devops].include? resp.user
      end

      def cmd_help(resp)
        list = get_script_list(resp, config)

        out = list.sort.join("\n")
        resp.reply_privately code_blockify(out)
      end

      ### CMD ###################################################

      route(/^\s*cmd\s+(\S*)\s*(.*)$/, :cmd, command: true, help: {
        "cmd SCRIPT" => "run the SCRIPT specified; use `lita cmd help` for a list"
      })

      def cmd(resp)
        script = resp.matches[0][0]
        opts = CSV::parse_line(resp.matches[0][1], col_sep: ' ')

        unless user_is_authorized(script, resp, config)
          resp.reply_privately "Unauthorized to run '#{script}'!"
          return
        end

        out = String.new
        err = String.new
        Open3.popen3("export LITA_USER='#{resp.user.name}';#{config.scripts_dir}/#{script}", *opts) do |i, o, e, wait_thread|
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

      def get_script_list(resp, config)
        bot = Lita::Robot.new
        auth = bot.auth

        list = Dir.entries(config.scripts_dir).select { |f| File.file? "#{config.scripts_dir}/#{f}" }

        groups = auth.groups_with_users.select { |group, user_list| user_list.include? resp.user }
        groups.keys.each do |group|
          begin
            sublist = Dir.entries("#{config.scripts_dir}/#{group}").select do |f|
              File.file? "#{config.scripts_dir}/#{group}/#{f}"
            end
          rescue SystemCallError => e
            log.warn "#{group} is not a directory.\n#{e}"
          end
          list.concat sublist.map { |x| "#{group}/#{x}" } if sublist
        end

        list
      end

      def user_is_authorized(script, resp, config)
        list = get_script_list(resp, config)
        list.include? script
      end
    end

    Lita.register_handler(Cmd)
  end
end
