require 'open3'

module Lita
  module Handlers
    class Cmd < Handler
      on :connected, :create_routes
      config :scripts_dir, required: true
      config :output_format, default: "```\n%s\n```"
      config :stdout_prefix, default: "[stdout] "
      config :stderr_prefix, default: "[stderr] "
      config :command_prefix, default: "cmd "

      def create_routes(payload)
        self.class.route(/^\s*#{config.command_prefix}(\S*)\s*(.*)$/, :run_action, command: true, help: {
          "#{config.command_prefix}ACTION" => "run the specified ACTION. use `#{robot.name} #{config.command_prefix}list` for a list of available actions."
        })
      end

      def run_action(resp)
        script = resp.matches[0][0]
        opts = resp.matches[0][1].split(" ")
        return show_help(resp) if script == 'list'

        unless user_is_authorized(script, resp, config)
          resp.reply_privately "Unauthorized to run '#{script}'!"
          return
        end

        out = String.new
        err = String.new
        Open3.popen3("#{config.scripts_dir}/#{script}", *opts) do |i, o, e, wait_thread|
          o.each { |line| out << "#{config.stdout_prefix}#{line}" }
          e.each { |line| err << "#{config.stderr_prefix}#{line}" }
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

      def show_help(resp)
        list = get_script_list(resp, config)

        out = list.sort.join("\n")
        resp.reply_privately code_blockify(out)
      end

      private

      def code_blockify(text)
        config.output_format % text
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
