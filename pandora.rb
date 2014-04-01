require 'mycroft'

class Pandora < Mycroft::Client

  def initialize(host, port)
    @key = '/path/to/key'
    @cert = '/path/to/cert'
    @manifest = './app.json'
    @verified = false
    @sent_grammar = false
    super
  end

  on 'APP_DEPENDENCY' do |data|
    if not @dependencies['stt'].nil?
      if @dependencies['stt']['stt1'] == 'up' and not @sent_grammar
        up
        data = {grammar: { name: 'pandora', xml: File.read('./grammar.xml')}}
        query('stt', 'load_grammar', data)
        @sent_grammar = true
      elsif @dependencies['stt']['stt1'] == 'down' and @sent_grammar
        @sent_grammar = false
        down
      end
    end
  end

  # Any other event handlers

end

Mycroft.start(Pandora)
