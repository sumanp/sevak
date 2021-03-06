require 'minitest_helper'

module Sevak

  describe Publisher do
    before do
      Sevak.configure do |f|
        f.host = 'localhost'
        f.port = '5672'
      end
      @pub = Publisher.send(:new)
      @queue_name = 'sms'
    end

    it 'should have a publish method' do
      assert_equal true, Publisher.respond_to?(:publish)
    end

    it 'should have a delayed_publish method' do
      assert_equal true, Publisher.respond_to?(:delayed_publish)
    end

    describe '#channel' do
      it 'should create a channel' do
        @pub.channel
        refute_nil @pub.instance_variable_get(:@channel)
      end
    end

    describe '#queue' do
      it 'should create a queue with the given name' do
        @pub.queue(@queue_name)
        refute_nil @pub.instance_variable_get(:@queue)
        assert_equal @pub.instance_variable_get(:@queue).name, @queue_name
      end
    end

    describe '#publish' do
      it 'should publish message to the queue specified' do
        Publisher.publish(@queue_name, { msisdn: '+919894321290', message: 'Testing the message publish' })
      end
    end

    describe '#exchange' do
      before do
        @pub.exchange('sms')
      end

      it 'should create an exchange with name #{@queue_name}_exchange specified' do
        refute_nil @pub.instance_variable_get(:@exchange)
        assert_equal @pub.instance_variable_get(:@exchange).name, "#{@queue_name}_exchange"
      end

      it 'should create an exchange with type x-delayed-message' do
        assert_equal @pub.instance_variable_get(:@exchange).type, "x-delayed-message"
      end
    end

    describe '#delayed_publish' do
      before do
        @pub.queue(@queue_name).purge
        Publisher.delayed_publish(@queue_name, { msisdn: '+919894321290', message: 'Testing the delayed message publish' }, 10000)
      end

      it 'should route messages from the exchange to the queue' do
        assert_equal 0, @pub.queue(@queue_name).message_count
        sleep 20
        assert_equal 1, @pub.queue(@queue_name).message_count
      end
    end

  end
end
