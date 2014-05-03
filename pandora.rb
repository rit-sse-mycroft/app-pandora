require 'mycroft'

class Pandora < Mycroft::Client

  def initialize(host, port)
    @key = '/path/to/key'
    @cert = '/path/to/cert'
    @manifest = './app.json'
    @verified = false
    @sent_grammar = false
    @up = false
    @dependencies = {}
    @keycodes = {
      'play' => 'KEYCODE_MEDIA_PLAY_PAUSE',
      'next' => 'KEYCODE_MEDIA_NEXT',
      'up' => 'KEYCODE_VOLUME_UP',
      'down' => 'KEYCODE_VOLUME_DOWN'
    }
    super
  end

  on 'APP_DEPENDENCY' do |data|
    if not @dependencies['stt'].nil?
      if @dependencies['stt']['stt1'] == 'up' and @dependencies['pandora']['pandora'] == 'up' and not @up
        up
        @up = true
      elsif (@dependencies['stt']['stt1'] == 'down' or @dependencies['pandora']['pandora'] == 'down') and @up
        down
        @up = false
      end

      if @up and not @sent_grammar
        data = {grammar: { name: 'pandora', xml: File.read('./grammar.xml')}}
        query('stt', 'load_grammar', data)
        @sent_grammar = true
      elsif @dependencies['stt']['stt1'] == 'down' and @sent_grammar
        @sent_grammar = false
      end
    end
  end

  on 'MSG_BROADCAST' do |data|
    grammar = data['content']
    if grammar['grammar'] == 'pandora'
      action = grammar['tags']['action']
      unless action.nil?
        data =  {keycode: @keycodes[action]}
        query('gtv', 'send_keycode', data)
      else
        data = {uri: 'pandora://'}
        query('gtv', 'fling', data)
      end
    end
  end

  on 'CONNECTION_CLOSED' do
    query('stt', 'unload_grammar', {grammar: 'pandora'})
  end

  on 'ERROR' do |err|
    puts err
  end
end

Mycroft.start(Pandora, ARGV[0], ARGV[1])
