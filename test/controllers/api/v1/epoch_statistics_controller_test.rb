require "test_helper"

module Api
  module V1
    class EpochStatisticsControllerTest < ActionDispatch::IntegrationTest
      test "should set right content type when call index" do
        valid_get api_v1_epoch_statistic_url("difficulty-uncle_rate")

        assert_equal "application/vnd.api+json", response.media_type
      end

      test "should respond with 415 Unsupported Media Type when Content-Type is wrong" do
        get api_v1_epoch_statistic_url("difficulty-uncle_rate"), headers: { "Content-Type": "text/plain" }

        assert_equal 415, response.status
      end

      test "should respond with error object when Content-Type is wrong" do
        error_object = Api::V1::Exceptions::WrongContentTypeError.new
        response_json = RequestErrorSerializer.new([error_object], message: error_object.title).serialized_json

        get api_v1_epoch_statistic_url("difficulty-uncle_rate"), headers: { "Content-Type": "text/plain" }

        assert_equal response_json, response.body
      end

      test "should respond with 406 Not Acceptable when Accept is wrong" do
        get api_v1_epoch_statistic_url("difficulty-uncle_rate"), headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

        assert_equal 406, response.status
      end

      test "should respond with error object when Accept is wrong" do
        error_object = Api::V1::Exceptions::WrongAcceptError.new
        response_json = RequestErrorSerializer.new([error_object], message: error_object.title).serialized_json

        get api_v1_epoch_statistic_url("difficulty-uncle_rate"), headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

        assert_equal response_json, response.body
      end

      test "should return difficulty, uncle_rate and epoch number" do
        create_list(:epoch_statistic, 15)
        block_statistic_data = EpochStatistic.order(id: :desc)
        valid_get api_v1_epoch_statistic_url("difficulty-uncle_rate")

        assert_equal [%w(difficulty uncle_rate epoch_number).sort], json.dig("data").map { |item| item.dig("attributes").keys.sort }.uniq
        assert_equal EpochStatisticSerializer.new(block_statistic_data, { params: { indicator: "difficulty-uncle_rate" } }).serialized_json, response.body
      end

      test "should respond with error object when indicator name is invalid" do
        error_object = Api::V1::Exceptions::IndicatorNameInvalidError.new
        response_json = RequestErrorSerializer.new([error_object], message: error_object.title).serialized_json

        valid_get api_v1_epoch_statistic_url("hash_rates")

        assert_equal response_json, response.body
      end
    end
  end
end

