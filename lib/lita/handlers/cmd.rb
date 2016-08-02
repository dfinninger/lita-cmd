require 'open3'
require 'csv'

module Lita
  module Handlers
    class Cmd < Handler
      on :connected, :create_routes
      config :scripts_dir, required: true

      config :output_format, default: "%s"
      config :stdout_prefix, default: ""
      config :stderr_prefix, default: "ERROR: "
      config :command_prefix, default: "cmd "

      def create_routes(payload)
        self.class.route(/^\s*#{config.command_prefix}(\S+)\s*(.*)$/, :run_action, command: true, help: {
          "#{config.command_prefix}ACTION" => "run the specified ACTION. use `#{robot.name} #{config.command_prefix}list` for a list of available actions."
        })
      end

      def run_action(resp)
        script = resp.matches[0][0]
        opts = CSV::parse_line(resp.matches[0][1], col_sep: ' ')

        # the script will be the robot name if command_prefix is empty
        return if robot_name and script =~ /^@?#{robot_name}$/i

        return show_help(resp) if script == 'list'

        unless user_is_authorized(script, resp, config)
          resp.reply_privately "Unauthorized to run '#{script}'!" unless config.command_prefix.empty? 
          return
        end

        script_path = "#{config.scripts_dir}/#{script}"
        env_vars    = { 'LITA_USER' => resp.user.name }

        Open3.popen3(env_vars, script_path, *opts) do |i, o, e, wait_thread|
          o.each { |line| show_output(resp, "#{config.stdout_prefix}#{line}") }
          e.each { |line| show_output(resp, "#{config.stderr_prefix}#{line}") }
        end
      end

      def show_output(resp, line)
        # Scrub Unicode to ASCII
        encoding_options = {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => ''        # Use a blank for those replacements
        }
        ascii_out = line.encode(Encoding.find('ASCII'), encoding_options)

        ascii_out.split("\n").each_slice(50) do |slice|
          resp.reply code_format(slice.join("\n"))
        end
      end

      def show_help(resp)
        list = get_script_list(resp, config)

        out = list.sort.join("\n")
        resp.reply_privately code_format(out)
      end

      private

      def code_format(text)
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

      def robot_name
        return robot.name unless robot.name.empty?
        return robot.mention_name unless robot.mention_name.empty?
        return false
      end
    end

    Lita.register_handler(Cmd)
  end
end
