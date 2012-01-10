#!/usr/bin/ruby

class Applicant

  def initialize config_file
    if File.exist?(config_file)
      lines = IO.readlines(config_file)
      lines.each { |line| parse_line(line) }      
    else
      puts "Config file " + config_file + " not found!"
    end
	end

  def parse_line line    
    @name = parse_value(line,"name:") if line.start_with?("name:")
    @email = parse_value(line,"email:") if line.start_with?("email:")
    @about = parse_value(line,"about:") if line.start_with?("about:")
    @urls = parse_value(line,"urls:") if line.start_with?("urls:")   	  
  end

  def parse_value(line, field)  	  
  	return line.gsub(field,"").lstrip
  end

  def print
  	puts @name
  	puts @email
  	puts @about
  	puts @urls
  end

end


applicant = Applicant.new "aparse.cfg"
applicant.print