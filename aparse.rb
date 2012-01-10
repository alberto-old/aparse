#!/usr/bin/ruby

require 'json'
require 'net/http'

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
  	return line.gsub(field,"").lstrip.chomp
  end

  def print
  	puts @name
  	puts @email
  	puts @about
  	puts @urls
  end

  def generate_json    
    url_array = @urls.split("|").map {|url| url.lstrip.rstrip}

    @json = JSON.generate [ {"name" => @name}, 
                            {"email" => @email}, 
                            {"about" => @about}, 
                            {"urls" => url_array}]
  end

  def apply 
    # uri = URI('https://www.parse.com/jobs/apply')
    uri = URI('http://webhookapp.com/981496484418057223')
    request = Net::HTTP::Post.new(uri.path)
    request["content-type"] = "application/json"
    request.body = @json
    # post(request)
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        puts "You've applied to Parse!"
      else
        puts response.value
    end

  end


  def post request
  end

end


applicant = Applicant.new "aparse.cfg"
applicant.print
applicant.generate_json
applicant.apply