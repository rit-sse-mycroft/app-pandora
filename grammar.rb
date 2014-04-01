require 'srgs'

module JokeGrammar
  include Srgs::DSL

  extend self

  grammar 'toplevel' do

    private_rule 'volumeTypes' do
      one_of do
        item 'up'
        item 'down'
      end
    end

    private_rule 'volume' do
      item 'turn'
      reference '#volumeTypes'
      tag 'out.action=rules.volumeTypes;'
      item 'the volume on', repeat: '0-1'
    end

    private_rule 'actions' do
      item 'play'
      item 'pause' do
        tag 'out="play";'
      end
      item 'next'
      item 'play next' do
        tag 'out="next";'
      end
      item 'play the next' do
        tag 'out="next";'
      end
      item 'thumb up'
      item 'thumb down'
    end

    private_rule 'perform_action' do
      reference '#actions'
      tag 'out.action=rules.actions;'
      item 'the', repeat: '0-1'
      item 'song ', repeat: '0-1'
      item  'on', repeat: '0-1'
    end

    private_rule 'topLevel' do
      item "Mycroft"
      one_of do
        reference_item '#perform_action'
        reference_item '#volume'
      end
      item 'pandora'
    end
  end
end