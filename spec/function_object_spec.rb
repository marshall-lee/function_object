require 'spec_helper'

describe FunctionObject do
  let(:plus) do
    def_function do
      args do
        arg :a
        arg :b
      end

      def call
        a + b
      end
    end
  end

  it 'does something useful' do
    expect(plus.(1,2)).to eq 3
  end

  context 'when arguments are insufficient' do
    it 'raises ArgumentError' do
      expect {
        plus.(1)
      }.to raise_error(ArgumentError)
    end
  end

  describe 'default values' do
    let(:func) do
      def_function do
        args do
          arg :foo
          arg :bar, default: -> { foo * 2 }
        end

        def call
          "#{foo}_#{bar}"
        end
      end
    end

    it 'uses default value when argument is not passed' do
      expect(func.(2)).to eq '2_4'
    end

    it 'uses argument value when argument is passed' do
      expect(func.(1, 333)).to eq '1_333'
    end
  end
end
