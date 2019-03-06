require 'spec_helper'

describe Jsonapi::Matchers::ErrorIncluded do
  include Jsonapi::Matchers::Error

  let(:error) { 100 }

  context 'expected is not a request object' do
    let(:subject) { have_error.with_code(error) }
    let(:response) { String.new }

    before do
      subject.matches?(response)
    end

    it 'tells you that the response is not an ActionDispatch::TestResponse' do
      expect(subject.failure_message).to eq("Expected response to be ActionDispatch::TestResponse, ActionController::TestResponse, or hash but was \"\"")
    end
  end

  context 'expected is not a json body' do
    let(:subject) { have_error.with_code(error) }
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }
    let(:response_data) { nil }

    before do
      subject.matches?(response)
    end

    it 'tells you that the response body is not json' do
      expect(subject.failure_message).to match("Expected response to be json string but was \"null\". NoMethodError - undefined method `with_indifferent_access' for nil:NilClass")
    end
  end

  let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }

  describe 'have_error' do
    let(:subject) { have_error }

    context 'errors does not exist' do
      let(:response_data) { { data: [{ id: '3' }] } }

      it 'does not match' do
        expect(subject.matches?(response)).to be_falsey
      end

      it 'says the error is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match "expected any error code, but got ''"
      end
    end

    context 'errors is empty' do
      let(:response_data) { { errors: [] } }

      it 'does not match' do
        expect(subject.matches?(response)).to be_falsey
      end

      it 'says the error is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match "expected any error code, but got '[]'"
      end
    end

    context 'errors does not contain the error code' do
      let(:response_data) { { errors: [ { title: 'title', detail: 'detail', code: 99, status: 400 } ] } }

      it 'matches' do
        expect(subject.matches?(response)).to be_truthy
      end
    end

    context 'errors contains the error code' do
      let(:response_data) { { errors: [ { title: 'title', detail: 'detail', code: 100, status: 400 } ] } }

      it 'matches' do
        expect(subject.matches?(response)).to be_truthy
      end
    end
  end

  describe 'with_code' do
    let(:subject) { have_error.with_code(error) }

    context 'errors does not exist' do
      let(:response_data) { { data: [{ id: '3' }] } }

      it 'does not match' do
        expect(subject.matches?(response)).to be_falsey
      end

      it 'says the error is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match "expected error code '#{error}', but got ''"
      end
    end

    context 'errors is empty' do
      let(:response_data) { { errors: [] } }

      it 'does not match' do
        expect(subject.matches?(response)).to be_falsey
      end

      it 'says the error is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match "expected error code '#{error}', but got '[]'"
      end
    end

    context 'errors does not contain the error code' do
      let(:response_data) { { errors: [ { title: 'title', detail: 'detail', code: 99, status: 400 } ] } }

      it 'does not match' do
        expect(subject.matches?(response)).to be_falsey
      end

      it 'says the error is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match "expected error code '#{error}', but got '[{\"title\"=>\"title\", \"detail\"=>\"detail\", \"code\"=>99, \"status\"=>400}]'"
      end
    end

    context 'errors contains the error code' do
      let(:response_data) { { errors: [ { title: 'title', detail: 'detail', code: error, status: 400 } ] } }

      it 'matches' do
        expect(subject.matches?(response)).to be_truthy
      end
    end
  end
end
