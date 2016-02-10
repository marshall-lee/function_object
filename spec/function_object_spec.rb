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

  describe '.call' do
    it 'does something useful' do
      expect(plus.(1,2)).to eq 3
    end

    context 'with missing arguments ' do
      it 'raises ArgumentError' do
        expect {
          plus.(1)
        }.to raise_error(ArgumentError, /wrong number of arguments .*1.*2/)
      end
    end

    context 'with extra arguments' do
      it 'raises ArgumentError' do
        expect {
          plus.(1,2,3)
        }.to raise_error(ArgumentError, /wrong number of arguments .*3.*2/)
      end
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

  describe '.curry' do
    let(:curried) { plus.curry }
    subject { curried }

    it 'returns a callable object' do
      should respond_to :call
    end

    context 'with one argument bound' do
      let(:one_plus) { curried.(1) }
      subject { one_plus }

      it 'is still a callable object' do
        should respond_to :call
      end

      context 'when called with the rest of arguments' do
        subject { one_plus.(2) }

        it 'returns a value of function' do
          should eq 3
        end
      end
    end

    it 'allows to specify arity' do
      curried = plus.curry(2)
      expect(curried.(1,2)).to eq 3
      expect(curried.(2).(1)).to eq 3
    end

    it 'denies to curry with too small arity' do
      expect { plus.curry(0) }.to raise_error(ArgumentError, /wrong number of arguments .*0.*2/)
      expect { plus.curry(1) }.to raise_error(ArgumentError, /wrong number of arguments .*1.*2/)
    end

    it 'denies to curry with too big arity' do
      expect { plus.curry(3) }.to raise_error(ArgumentError, /wrong number of arguments .*3.*2/)
    end

    context 'function with optional arguments' do
      let(:func) do
        def_function do
          args {
            arg :x
            arg :y
            arg :s, default: -> { 3 }
            arg :t, default: -> { 4 }
          }
          def call
            [x,y,s,t]
          end
        end
      end

      it 'curries mandatoy arguments by default' do
        expect(func.curry.(2).(1)).to eq [2,1,3,4]
        expect(func.curry.(2,1)).to eq [2,1,3,4]
      end

      context 'with extra arguments' do
        it 'raises ArgumentError' do
          expect {
            func.curry.(1,2,3,4,5)
          }.to raise_error(ArgumentError, /wrong number of arguments .*5.*2\.\.4/)
        end
      end

      it 'allows to curry mandatory arguments' do
        expect(func.curry(2).(1,2)).to eq [1,2,3,4]
        expect(func.curry(2).(1).(2)).to eq [1,2,3,4]
      end

      it 'allows to curry optional arguments' do
        expect(func.curry(3).(1,2,5)).to eq [1,2,5,4]
        expect(func.curry(3).(1,2).(5)).to eq [1,2,5,4]
        expect(func.curry(3).(1).(2).(5)).to eq [1,2,5,4]
        expect(func.curry(4).(1,2,5).(6)).to eq [1,2,5,6]
        expect(func.curry(4).(1,2).(5).(6)).to eq [1,2,5,6]
        expect(func.curry(4).(1).(2).(5).(6)).to eq [1,2,5,6]
      end

      it 'denies to curry with too small arity' do
        expect { func.curry(0) }.to raise_error(ArgumentError, /wrong number of arguments .*0.*2\.\.4/)
        expect { func.curry(1) }.to raise_error(ArgumentError, /wrong number of arguments .*1.*2\.\.4/)
      end

      it 'denies to curry with too big arity' do
        expect { func.curry(5) }.to raise_error(ArgumentError, /wrong number of arguments .*5.*2\.\.4/)
      end
    end

    context 'function with no arguments' do
      let(:func) do
        def_function do
          def call
            123
          end
        end
      end

      context 'with extra arguments' do
        it 'raises ArgumentError' do
          expect {
            func.curry.(1)
          }.to raise_error(ArgumentError, /wrong number of arguments .*1.*0/)
        end
      end

      it 'allows to curry without arguments' do
        expect(func.curry.()).to eq(123)
      end

      it 'allows to curry with zero arguments' do
        expect(func.curry(0).()).to eq(123)
      end

      it 'denies to curry with too big arity' do
        expect { func.curry(1).() }.to raise_error(ArgumentError, 'wrong number of arguments (given 1, expected 0)')
      end
    end

    describe '.curry.to_proc' do
      let(:func) do
        def_function do
          args { arg :x; arg :y; arg :z }
          def call
            [x,y,z]
          end
        end
      end

      it 'returns an instance of Proc' do
        expect(func.curry.to_proc).to be_kind_of Proc
      end

      it 'acts like curry itself' do
        block = func.curry.to_proc
        expect(block.(1,2,3)).to eq [1,2,3]
        expect(block.(1,2).(3)).to eq [1,2,3]
        expect(block.(1).(2,3)).to eq [1,2,3]
        expect(block.(1).(2).(3)).to eq [1,2,3]
      end
    end
  end
end
