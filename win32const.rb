# frozen_string_literal: true

Dir.chdir __dir__

CACHE, TAGS, = (File.read '.gitignore').lines.map &:chomp

PATHS = ENV['PATH'].split(';').map { |e| e.tr('\\', '/') }

def which file
  PATHS.map { |e| File.join e, file }.find { |e| File.executable? e }
end

def ensure_which *files
  unless files.all? { |f| which f }
    puts "Requies #{files.join ', '} in PATH"
    exit 1
  end
end

ensure_which 'gcc.exe', 'ctags.exe'

def which_to file, path
  File.expand_path File.join (File.dirname which file), path
end

INCLUDE = which_to 'gcc.exe', '../x86_64-w64-mingw32/include'

unless File.exist? CACHE
  unless File.exist? TAGS
    system 'ctags', '-Rnf', TAGS, (File.join INCLUDE, '*')
  end
  files = {}
  cache = {}
  open TAGS do |f|
    f.each_line do |l|
      next if l.start_with? '!'
      (x, file, lineno), (_, t, y), = (l.split ';"').map { |e| e.split(/\t/) }
      i = files[(file.delete_prefix INCLUDE + '/')] ||= files.size
      (cache[x] ||= []) << [i, lineno.to_i, t.chomp, y]
    end
  end
  open CACHE, 'wb' do |f|
    Marshal.dump [files.keys, cache], f
  end
end

if ARGV.empty?
  puts "Usage: ruby #$0 WINAPI"
  exit
end

FILES, Cache = open CACHE, 'rb' do |f| Marshal.load f end
KEYS = Cache.keys

def search k, from = nil
  if Cache.key? k
    Cache[k].each do |(i, lineno, t, y)|
      f = open File.join INCLUDE, FILES[i]
      (lineno - 1).times { f.gets }
      line =  f.gets
      if from and line.lstrip.start_with? 'typedef'
        puts "#{FILES[i]}:#{lineno}\n#{line}"
        puts line = f.gets until line == from
      else
        puts "#{FILES[i]}:#{lineno}\t#{line}"
      end
      f.close
      if t == 't' and y and /typeref:struct:(?<ref>\w+)/ =~ y
        search ref, line
      end
    end
  else
    possibles = KEYS.grep Regexp.new k, 1
    if possibles.empty?
      puts "don't know #{k}"
    else
      puts "don't know #{k}, did you mean?"
      possibles.each_with_index do |k, i|
        if i >= 20
          puts "\t... #{possibles.size} possible results"
          break
        else
          puts "\t#{k}"
        end
      end
    end
  end
end

ARGV.each { |k| search k }
