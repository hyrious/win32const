# coding: utf-8

M32 = !!(ARGV.delete '-m32')

require 'erb'
TEMPLATE = ERB.new <<~CPP, 0, "%<>"
  #include <windows.h>
  % argv = ARGV.group_by { |s| s.end_with? '.h' }
  % argv[true]&.each do |what|
  #include <<%= what %>>
  % end
  #include <iostream>
  int main() {
  % argv[false]&.each do |what|
    std::cout << <%= what.inspect %> << "="
              << sizeof(<%= what %>) << std::endl;
  % end
    return 0;
  }
CPP

require 'tempfile'
Tempfile.open(['a', '.cpp']) do |f|
  f.write TEMPLATE.result
  f.close
  Tempfile.open(['a', '.exe']) do |g|
    g.close
    m32 = M32 ? ['-m32'] : []
    if system 'g++', *m32, '-o', g.path, '-w', '-s', '-O', f.path
      system g.path
    else
      system 'powershell', 'Write-Host', '-F', 'Red', '[!] Failed'
    end
  end
end
