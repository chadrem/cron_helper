module CronHelper
  class Job
    def self.register(method_name)
      @cron_methods ||= []
      @cron_methods << method_name
    end

    def run
      backup_streams
      hijack_streams

      result = ''

      file_lock do
        cron_methods.each do |m|
          @output.truncate(0)

          begin
            send(m)
          rescue Exception => e
            @output.string.chomp!
            puts "\n" if @output.string.length > 0
            puts "EXCEPTION #{e.class} (#{e.message.chomp})\n#{e.backtrace.join("\n")}\n"
          ensure
            if @output.string.length > 0
              result << "#######################################################\n"
              result << "#{self.class.to_s}##{m.to_s}\n"
              result << "#######################################################\n"
              result << "#{@output.string.chomp}\n"
              result << "---\n\n"
            end
          end
        end
      end
    ensure
      restore_streams
      output_handler(result)
    end

    private

    def output_handler(output)
      puts output if output.length > 0
    end

    def cron_methods
      self.class.instance_variable_get('@cron_methods') || []
    end

    def backup_streams
      @stderr_backup = $stderr
      @stdout_backup = $stdout
    end

    def restore_streams
      return unless @stderr_backup && @stdout_backup

      $stderr = @stderr_backup
      $stdout = @stdout_backup

      @stderr_backup = @stdout_backup = nil
    end

    def hijack_streams
      @output = $stderr = $stdout = StringIO.new
    end

    def file_lock(&block)
      FileUtils.mkdir_p(lock_dir_path)

      File.open(lock_file_path, File::RDWR|File::CREAT, 0644) do |f|
        unless f.flock(File::LOCK_EX|File::LOCK_NB)
          puts "CRON FAILED TO LOCK (#{cron_name} at #{Time.zone.now})"
          return
        end

        begin
          yield
        rescue Exception => e
          puts "CRON EXCEPTION (#{cron_name} at #{Time.zone.now}): #{e.message}\n#{e.backtrace}"
        ensure
          f.flock(File::LOCK_UN)
        end
      end
    end

    def cron_name
      return self.class.to_s
    end

    def lock_dir_path
      return File.join(Rails.root, 'tmp', 'crons')
    end

    def lock_file_name
      return "#{cron_name}.lock"
    end

    def lock_file_path
      return File.join(lock_dir_path, lock_file_name)
    end
  end
end
