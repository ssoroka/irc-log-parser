#!/usr/bin/env ruby
require 'rubygems'
require 'chronic'

class Parser
  LOOK_AHEAD = 100

  # [00:48] tobago (n=Chris@unaffiliated/tobago) joined #rubyonrails.
  JOIN_LINE = /\[[\d\:]+\] (.*?) \(.*?\) joined \#.+$/
  # [00:55] mrkris (n=mrkris@c-24-19-164-97.hsd1.wa.comcast.net) left irc: 
  # [01:10] skindogz (n=skindogz@c-71-197-28-22.hsd1.mi.comcast.net) left #rubyonrails.
  LEAVE_LINE = /\[([\d\:]+)\] (.*?) \(.*?\) left .+$/
  CHAT_LINE = /\[([\d\:]+)\] \<(.*?)\> (.*)$/
  
  attr_accessor :lines, :conversations, :nick_list
  def initialize(text)
    @nick_list = []
    objectify(text)
    extract_conversations
  end

  def objectify(text)
    @lines = []
    text.split(/\n/).map{|l|
      case l
      when CHAT_LINE:
        add_nick($2)
        @lines << Line.new($1, $2, $3, @nick_list)
        # l = Line.new(l.scan(CHAT_LINE).first)
        
        # add_nick(l.name)
        # l.nick_list = @nick_list.dup
        # @lines << l
      when JOIN_LINE:
        add_nick($2)
      when LEAVE_LINE:
        remove_nick($2)
      end
    }
  end
  
  def extract_conversations
    @conversations = []
    @lines.each_with_index{|start_line, start|
      if start_line.question?
        @lines[(start + 1)..(start + LOOK_AHEAD)].each_with_index{|end_line, end_index|
          if start_line.name == end_line.name && end_line.thanks?
            convo = @lines[start..end_index]
            responders = convo.select{|cline| cline.text[0..(start_line.name.size - 1)]}
            # c = Conversation.new(:asker => line.name, :responders => )
            break
          end
        }
      end
    }
  end
  
  def add_nick(nick)
    @nick_list << nick unless @nick_list.include?(nick)
  end

  def remove_nick(nick)
    @nick_list.delete(nick)
  end
end

class Line
  QUESTION = /\b(how (do|should) (you|i))\b/i
  THANKS = /\b(thanks|thank you|tha?nx|thx|ty|awesome|sweet|wicked)\b/i
  AFFIRMATIVE = /\b(yes|yeah|yep)\b/
  NEGATIVE = /\b(no|nope|didn't work)\b/
  
  attr_accessor :time, :name, :text, :nick_list, :classifications

  def initialize(time, name, text, nick_list)
    @time, @name, @text, @nick_list = Chronic.parse(time), name, text, nick_list.dup
    classify
  end
  
  def classify
    @classifications = Line.constants.map{|const|
      const.downcase if @line =~ const
    }.compact
  end
  
  def method_missing(m, *a, &b)
    if m.to_s =~ /\?$/ && Line.constants.include?(m.to_s[0..-2].upcase)
      @classifications.include?(m.to_s[0..-2])
    else
      super(m, *a, &b)
    end
  end
end

class Conversation
  # spans multiple lines
  # has an asker
  # has an answerer
end

parser = Parser.new(File.read(ARGV.first))

# puts lines.map{|l| l.name}.compact.sort{|a,b| a <=> b}.uniq.join("\n")
