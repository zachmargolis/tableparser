require 'spec_helper'
require 'open3'
require 'timeout'
require 'pty'

RSpec.describe 'exe/' do
  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  def executable(name)
    File.join(ROOT_DIR, 'exe', name)
  end

  describe 'tableparser' do
    context 'no data stdin (stdin is TTY)' do
      it 'fails and prints usage instructions STDERR' do
        err_r, err_w = IO.pipe

        success = system(executable('tableparser'), err: err_w)
        expect(success).to eq(false)

        err_w.close
        expect(err_r.read).to include('Usage:')
      end
    end

    context 'stdin has data' do
      let(:stdin) do
        <<~EOS
          +---------+---------+
          | col1    | col2    |
          +---------+---------+
          | val     | val     |
          | val     | val     |
          +---------+---------+
        EOS
      end

      it 'converts to a CSV' do
        output = exe('tableparser', stdin: stdin)

        expect(output).to eq(<<~EOS)
          col1,col2
          val,val
          val,val
        EOS
      end
    end
  end

  def exe(file, *args, stdin: nil, timeout: 3)
    path = executable(file)
    raise ArgumentError, "no executable named #{file}" if !File.exists?(path)
    opts = {}
    if !stdin
      pty_in, pty_out = PTY.open
      opts[:in] = pty_out
      opts[:out] = pty_in
    end
    Open3.popen3(path, *args, opts) do |p_stdin, p_stdout, p_stderr, wait_thread|
      if stdin
        p_stdin.puts stdin
        p_stdin.close
      end


      begin
        Timeout.timeout(timeout) do
          if wait_thread.value.success?
            p_stdout.read
          else
            raise "executable failed: #{wait_thread.value}, stderr=#{p_stderr.read}"
          end
        end
      rescue Timeout::Error => e
        Process.kill("KILL", wait_thread.pid)
        raise e
      end
    end
  ensure
    pty_in && pty_in.close
    pty_out && pty_out.close
  end
end
