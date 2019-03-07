require 'spec_helper'

describe Jsonapi::Matchers::RecordCount do
  include Jsonapi::Matchers::Record

  let(:count) { 3 }

  context 'expected is not a request object' do
    let(:subject) { have_record_count(count) }
    let(:response) { String.new }

    before do
      subject.matches?(response)
    end

    it 'tells you that the response is not an ActionDispatch::TestResponse' do
      expect(subject.failure_message).to eq("Expected response to be ActionDispatch::TestResponse, ActionController::TestResponse, or hash but was \"\"")
    end
  end

  context 'expected is not a json body' do
    let(:subject) { have_record_count(count) }
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }
    let(:response_data) { nil }

    before do
      subject.matches?(response)
    end

    it 'tells you that the response body is not json' do
      expect(subject.failure_message).to match("Expected response to be json string but was \"null\". NoMethodError - undefined method `with_indifferent_access' for nil:NilClass")
    end
  end

  context 'checks :included' do
    let(:subject) { include_record_count(count) }
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }
    let(:response_data) do
      {
        included: [
          { id: '3' },
          { id: '4' },
          { id: '5' }
        ]
      }
    end

    context 'count is correct' do
      it 'matches' do
        expect(subject.matches?(response)).to eq true
      end
    end

    context 'expected count is less than the actual' do
      let(:count) { 2 }

      it 'does not match' do
        expect(subject.matches?(response)).to eq false
      end

      it 'says the id is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match(/expected object count '2', but was 3/)
      end
    end

    context 'expected count is more than the actual' do
      let(:count) { 4 }

      it 'does not match' do
        expect(subject.matches?(response)).to eq false
      end

      it 'says the id is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match(/expected object count '4', but was 3/)
      end
    end
  end

  context 'checks :data' do
    let(:subject) { have_record_count(count) }
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }

    context 'data is an array' do
      let(:response_data) do
        {
          data: [
            { id: '3' },
            { id: '4' },
            { id: '5' }
          ]
        }
      end

      context 'count is correct' do
        it 'matches' do
          expect(subject.matches?(response)).to eq true
        end
      end

      context 'expected count is less than the actual' do
        let(:count) { 2 }

        it 'does not match' do
          expect(subject.matches?(response)).to eq false
        end

        it 'says the id is not in the response' do
          subject.matches?(response)
          expect(subject.failure_message).to match(/expected object count '2', but was 3/)
        end
      end

      context 'expected count is more than the actual' do
        let(:count) { 4 }

        it 'does not match' do
          expect(subject.matches?(response)).to eq false
        end

        it 'says the id is not in the response' do
          subject.matches?(response)
          expect(subject.failure_message).to match(/expected object count '4', but was 3/)
        end
      end
    end

    context 'data is an object' do
      let(:response_data) do
        {
          data: {
            id: '3'
          }
        }
      end

      context 'count is correct' do
        let(:count) { 1 }

        it 'matches' do
          expect(subject.matches?(response)).to eq true
        end
      end

      context 'expected count is less than the actual' do
        let(:count) { 0 }

        it 'does not match' do
          expect(subject.matches?(response)).to eq false
        end

        it 'says the id is not in the response' do
          subject.matches?(response)
          expect(subject.failure_message).to match(/expected object count '0', but was 1/)
        end
      end

      context 'expected count is more than the actual' do
        let(:count) { 2 }

        it 'does not match' do
          expect(subject.matches?(response)).to eq false
        end

        it 'says the id is not in the response' do
          subject.matches?(response)
          expect(subject.failure_message).to match(/expected object count '2', but was 1/)
        end
      end
    end
  end
end
