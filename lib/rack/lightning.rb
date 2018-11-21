require "rack/lightning/version"
require 'digest'

require 'rack/lightning/rpc_services_pb'

module Rack
  class Lightning

    def initialize(app, options={})
      @app = app
      @invoice_storage = {} # TODO: don't store this in memory!
      @options = options
      @price = @options[:price] || 100
      @options[:address] ||= 'localhost:10009'
      @options[:timeout] ||= 5
      @options[:credentials] ||= ::File.read(::File.expand_path(@options[:credentials_path] || "~/.lnd/tls.cert"))
      @options[:macaroon] ||= begin
        macaroon_binary = ::File.read(::File.expand_path(@options[:macaroon_path] || "~/.lnd/data/chain/bitcoin/testnet/admin.macaroon"))
        macaroon_binary.each_byte.map { |b| b.to_s(16).rjust(2,'0') }.join
      end
      @lnd_client = Lnrpc::Lightning::Stub.new(@options[:address], GRPC::Core::ChannelCredentials.new(@options[:credentials]))
    end

    def call(env)
      if self.paid?(env)
        @app.call(env)
      else
        invoice = self.generate_invoice(env)
        [402, { 'Content-Type' => 'application/vnd.lightning.bolt11' }, [invoice.payment_request]]
      end
    end

    def price
      @price
    end

    def paid?(env)
      preimage = env['HTTP_X_PREIMAGE']
      return false unless preimage

      hexdecoded = [preimage].pack('H*')
      preimage_hash = Digest::SHA256.digest(hexdecoded)
      preimage_hash_hex = preimage_hash.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join

      return false if used?(preimage_hash_hex)

      invoice = Lnrpc::PaymentHash.new(r_hash_str: preimage_hash_hex, r_hash: preimage_hash)
      begin
        response = @lnd_client.lookup_invoice(invoice, { metadata: { macaroon: @options[:macaroon] }})
        if response.settled
          @invoice_storage[preimage_hash_hex] = true
          return true
        else
          return false
        end
      rescue Exception => e
        return false
      end
    end

    def used?(preimage_hash_hex)
      !@invoice_storage[preimage_hash_hex].nil?
    end

    def hash_preimage(preimage)
      hexdecoded = preimage.pach('H*')
      hash = Digest::SHA256.digest(hexdecoded)
      hash.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join
    end

    def generate_invoice(env)
      invoice_request = Lnrpc::Invoice.new(memo: "API request #{env['REQUEST_URI']}", value: self.price)
      @lnd_client.add_invoice(invoice_request, { metadata: { macaroon: @options[:macaroon] }})
    end

  end
end
