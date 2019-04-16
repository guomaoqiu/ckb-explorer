require "test_helper"

module CkbSync
  class AuthenticSyncTest < ActiveSupport::TestCase
    setup do
      SyncInfo.local_authentic_tip_block_number
    end

    test "should create 11 blocks when inauthentic sync start" do
      Sidekiq::Testing.inline! do
        CkbSync::Api.any_instance.stubs(:get_tip_block_number).returns(20)

        assert_difference "Block.count", 11 do
          VCR.use_cassette("genesis_block", match_requests_on: [:body]) do
            VCR.use_cassette("blocks/two", match_requests_on: [:body]) do
              CkbSync::AuthenticSync.start
            end
          end
        end
      end
    end

    test "should queueing 11 job" do
      Sidekiq::Testing.fake!
      CkbSync::Api.any_instance.stubs(:get_tip_block_number).returns(20)

      VCR.use_cassette("genesis_block", match_requests_on: [:body]) do
        VCR.use_cassette("blocks/two", match_requests_on: [:body]) do
          assert_changes -> { CheckBlockWorker.jobs.size }, from: 0, to: 11 do
            CkbSync::AuthenticSync.start
          end
        end
      end
    end
  end
end