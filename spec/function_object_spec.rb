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

  let(:constant) do
    def_function do
      def call
        :hello
      end
    end
  end

  let(:void) do
    def_function do
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

  describe '.to_proc' do
    subject { plus.to_proc }

    it 'returns a Proc instance' do
      should be_kind_of Proc
    end

    describe '#call' do
      it 'returns a functional call value' do
        expect(subject.(1,2)).to eq 3
      end
    end

    describe 'passing as a block' do
      it 'can be called using yield' do
        ret = Module.new do
          def self.call
            4 + (yield 1, 2)
          end
        end.(&plus)
        expect(ret).to eq 7
      end
    end
  end

  describe 'function object without arguments' do
    context 'which does not implement instance method #call' do
      subject { void }
      it { should respond_to :call }

      describe '.call' do
        it 'should return nil' do
          expect(subject.()).to eq nil
        end
      end
    end

    context 'which implements instance method #call' do
      subject { constant }
      it { should respond_to :call }

      describe '.call' do
        it 'should return a value of calling instance method #call' do
          expect(subject.()).to eq :hello
        end
      end
    end
  end
end
