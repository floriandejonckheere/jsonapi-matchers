require 'spec_helper'

describe Jsonapi::Matchers::RecordIncluded do
  include Jsonapi::Matchers::Record

  let(:id) { }
  let(:record) { double(:record, {id: id}) }

  let(:ids) { [] }
  let(:records) { ids.map { |i| double(:record, {id: i}) } }

  context 'expected is not a request object' do
    let(:subject) { have_record(record) }
    let(:response) { String.new }

    before do
      subject.matches?(response)
    end

    it 'tells you that the response is not an ActionDispatch::TestResponse' do
      expect(subject.failure_message).to eq("Expected response to be ActionDispatch::TestResponse, ActionController::TestResponse, or hash but was \"\"")
    end
  end

  context 'expected is not a json body' do
    let(:subject) { have_record(record) }
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
    let(:subject) { include_record(record) }
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }
    let(:response_data) do
      {
        included: [{
          id: '3'
        }]
      }
    end

    context 'record is found' do
      let(:id) { '3' }

      it 'matches' do
        expect(subject.matches?(response)).to eq true
      end
    end

    context 'record is not found' do
      let(:id) { 'other_value' }

      it 'does not match' do
        expect(subject.matches?(response)).to eq false
      end

      it 'says the id is not in the response' do
        subject.matches?(response)
        expect(subject.failure_message).to match(/expected object with an id of 'other_value' to be included in /)
      end
    end
  end

  context 'checks :data' do
    let(:response) { ActionDispatch::TestResponse.new(response_data.to_json) }

    describe 'have_record' do
      let(:subject) { have_record(record) }

      context 'data is an array' do
        let(:response_data) do
          {
            data: [{
                     id: '3'
                   }]
          }
        end

        context 'record is found' do
          let(:id) { '3' }

          it 'matches' do
            expect(subject.matches?(response)).to eq true
          end

          context 'the record id is not a string' do
            let(:id) { 3 }

            it 'matches' do
              expect(subject.matches?(response)).to eq true
            end
          end
        end

        context 'record is not found' do
          let(:id) { 'other_value' }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected object with an id of 'other_value' to be included in /)
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

        let(:record) { double(:record, {id: id}) }

        context 'record is found' do
          let(:id) { '3' }

          it 'matches' do
            expect(subject.matches?(response)).to eq true
          end

          context 'the record id is not a string' do
            let(:id) { 3 }

            it 'matches' do
              expect(subject.matches?(response)).to eq true
            end
          end
        end

        context 'record is not found' do
          let(:id) { 'other_value' }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected object with an id of 'other_value' to be included in /)
          end
        end

        context 'handles negated failure cases' do
          let(:id) { '3' }

          it 'does not blow up' do
            begin
              expect(response).to_not have_record(record)
            rescue NoMethodError => e
              fail("Should be able to handle negated cases without throwing an error: " + e.to_s)
            rescue RSpec::Expectations::ExpectationNotMetError
            end
          end

          it 'shows a negated error message' do
            @failure = nil
            begin
              expect(response).to_not have_record(record)
            rescue RSpec::Expectations::ExpectationNotMetError => e
              @failure = e.message
            end
            expect(@failure).to match(/expected object with an id of '3' to not be included in /)
          end
        end
      end
    end

    describe 'have_records' do
      let(:subject) { have_records(records) }

      context 'data is an array' do
        let(:response_data) do
          {
            data: [{
                     id: '3'
                   },{
                      id: '4'
                    }]
          }
        end

        context 'records are found' do
          let(:ids) { %w(3 4) }

          it 'matches' do
            expect(subject.matches?(response)).to eq true
          end

          context 'the record ids are not strings' do
            let(:ids) { [3, 4] }

            it 'matches' do
              expect(subject.matches?(response)).to eq true
            end
          end
        end

        context 'records are not found' do
          let(:ids) { %w(5 6) }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected objects with ids of '5', '6' to be included in /)
          end
        end

        context 'records are only partially found' do
          let(:ids) { %w(4 5) }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected objects with ids of '4', '5' to be included in /)
          end
        end

        context 'handles negated failure cases' do
          let(:ids) { %w(3 4) }

          it 'does not blow up' do
            begin
              expect(response).to_not have_records(records)
            rescue NoMethodError => e
              fail("Should be able to handle negated cases without throwing an error: " + e.to_s)
            rescue RSpec::Expectations::ExpectationNotMetError
            end
          end

          it 'shows a negated error message' do
            @failure = nil
            begin
              expect(response).to_not have_records(records)
            rescue RSpec::Expectations::ExpectationNotMetError => e
              @failure = e.message
            end
            expect(@failure).to match(/expected objects with ids of '3', '4' to not be included in /)
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

        context 'records are found' do
          let(:ids) { %w(3) }

          it 'matches' do
            expect(subject.matches?(response)).to eq true
          end

          context 'the record id is not a string' do
            let(:ids) { [3] }

            it 'matches' do
              expect(subject.matches?(response)).to eq true
            end
          end
        end

        context 'records are not found' do
          let(:ids) { %w(4) }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected objects with ids of '4' to be included in /)
          end
        end

        context 'records are only partially found' do
          let(:ids) { %w(3 4) }

          it 'does not match' do
            expect(subject.matches?(response)).to eq false
          end

          it 'says the id is not in the response' do
            subject.matches?(response)
            expect(subject.failure_message).to match(/expected objects with ids of '3', '4' to be included in /)
          end
        end
      end
    end
  end
end
