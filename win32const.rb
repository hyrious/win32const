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

SUBL = !!(ARGV.delete '--subl')
M32 = !!(ARGV.delete '-m32')

def search k, from = nil, file = nil
  if Cache.key? k
    Cache[k].each do |(i, lineno, t, y)|
      path = File.join INCLUDE, FILES[i]
      f = open path
      (lineno - 1).times { f.gets }
      line = f.gets
      if from
        if file == FILES[i] and line.lstrip.start_with? 'typedef'
          puts "#{FILES[i]}:#{lineno}\n#{line}"
          puts line = f.gets until line == from
        end
      else
        puts "#{FILES[i]}:#{lineno}\t#{line}"
      end
      f.close
      system 'subl', '-a', "#{path}:#{lineno}" if SUBL
      if t == 't' and y and /typeref:struct:(?<ref>\w+)/ =~ y
        search ref, line, FILES[i]
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

def utf8 str
  str.encode("UTF-8", Encoding.default_external, replace: '?', invalid: :replace, undef: :replace, fallback: '?').chomp("\n")
end

require 'tempfile'
def abi k
  Tempfile.open(['a-', '.cpp']) do |f|
    f.write <<~C
      #define S(s) X(s)
      #define X(s) #s
      #include<windows.h>
      #include<d3d11.h>
      #include<bits/stdc++.h>
      int main(){puts(("" S(#{k})));}
    C
    f.close
    Tempfile.open(['a-', '.exe']) do |o|
      o.close
      raw = utf8 `2>&1 g++ -w -O -m32 #{f.path.inspect} -o #{o.path.inspect} && #{o.path.inspect}`
      if raw == k
        open(f,'w') { |g| g.write <<~C }
          #include<windows.h>
          #include<d3d11.h>
          #include<cxxabi.h>
          #include<bits/stdc++.h>
          int main(){
            int status;
            char*name=abi::__cxa_demangle(typeid(#{k}).name(),0,0,&status);
            puts(name);free(name);
          }
        C
        puts utf8 `2>&1 g++ -w -O -m32 #{f.path.inspect} -o #{o.path.inspect} && #{o.path.inspect}`
      else
        puts raw
      end
    end
  end
end

puts INCLUDE.tr('/', '\\')
ARGV.each { |k| search k; abi k }
