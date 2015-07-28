require "spec_helper"
require "./bbcode_progress.rb"

RSpec.describe BBCodeProgress do
  def expect_progress(p, label, value, max)
    expect(p.label).to eq(label)
    expect(p.value).to eq(value)
    if max.nil?
      expect(p.max).to be_nil
    else
      expect(p.max).to eq(max)
    end
  end

  context "creating new object" do
    it "sets label and value" do
      p = BBCodeProgress.new("foo", 1)
      expect_progress(p, "foo", 1, nil)
    end

    it "sets label, value, and max" do
      p = BBCodeProgress.new("foo", 1, 42)
      expect_progress(p, "foo", 1, 42)
    end

    it "accepts Amount objects" do
      p = BBCodeProgress.new("foo", Amount.parse_string("1"))
      expect_progress(p, "foo", 1, nil)
    end

    it "generates BBCode" do
      p = BBCodeProgress.new("foo", 1, 42)
      expect(p.to_s).to eq("[progress=foo]1/42[/progress]")
    end

    it "fails if max is absent before calling to_s" do
      p = BBCodeProgress.new("foo", 1)
      expect{p.to_s}.to raise_error("ERROR[foo]: must set @max before calling to_s")
    end
  end

  context "parsing command-line arguments" do
    it "parses item with value" do
      items = BBCodeProgress.parse_args(["foo=1"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 1, nil)
    end

    it "parses item with max" do
      items = BBCodeProgress.parse_args(["foo=/42"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", nil, 42)
    end

    it "parses item with value and max" do
      items = BBCodeProgress.parse_args(["foo=1/42"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 1, 42)
    end

    it "parses item with fractional value" do
      items = BBCodeProgress.parse_args(["foo=.1"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 0.1, nil)
    end

    it "parses item with fractional value with leading zero" do
      items = BBCodeProgress.parse_args(["foo=0.1"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 0.1, nil)
    end

    it "parses item with fractional value and int max" do
      items = BBCodeProgress.parse_args(["foo=.1/42"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 0.1, 42)
    end

    it "parses item with fractional value with leading zero and int max" do
      items = BBCodeProgress.parse_args(["foo=0.1/42"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 0.1, 42)
    end

    it "rejects item with fractional max" do
      expect{ BBCodeProgress.parse_args(["foo=1/4.2"]) }
          .to raise_error("ERROR: Max must be an integer")
    end

    it "parses item with fractional value and max" do
      expect{ BBCodeProgress.parse_args(["foo=.1/4.2"]) }
          .to raise_error("ERROR: Max must be an integer")
    end

    it "rejects item with no value" do
      items = BBCodeProgress.parse_args(["foo"])
      expect(items.length).to eq(0)
      items = BBCodeProgress.parse_args(["bar="])
      expect(items.length).to eq(0)
    end

    it "parses item with value greater than max" do
      items = BBCodeProgress.parse_args(["foo=42/37"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 42, 37)
    end

    it "parses multiple items" do
      items = BBCodeProgress.parse_args(["foo=1/42", "bar=2/37"])
      expect(items.length).to eq(2)
      expect_progress(items["foo"], "foo", 1, 42)
      expect_progress(items["bar"], "bar", 2, 37)
    end

    it "parses item with leading -- or -" do
      items = BBCodeProgress.parse_args(["--foo=1"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 1, nil)

      items = BBCodeProgress.parse_args(["-foo=1"])
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 1, nil)
    end

    it "parses item incrementing and/or decrementing" do
      values = [ nil, "+1", "2", "-3" ]
      maxes  = [ nil, "+2", "5", "-6" ]

      values.each do |value|
        maxes.each do |max|
          # Don't test when BOTH are nil; that case is handled elsewhere.
          next if value.nil? and max.nil?

          arg = "foo="
          arg += value unless value.nil?
          arg += "/" if max
          arg += max unless max.nil?

          items = BBCodeProgress.parse_args([arg])
          expect(items.length).to eq(1)
          expect_progress(items["foo"], "foo", value, max)
        end
      end
    end

  end

  context "parsing signature" do
    it "parses item with value and max" do
      sig = "[progress=foo]1/42[/progress]"
      items = BBCodeProgress.parse_sig(sig)
      expect(items.length).to eq(1)
      expect_progress(items["foo"], "foo", 1, 42)
    end

    it "ignores item with no max" do
      sig = "[progress=foo]1[/progress]"
      items = BBCodeProgress.parse_sig(sig)
      expect(items.length).to eq(0)
    end

    it "ignores item with no value" do
      sig = "[progress=foo]/42[/progress]"
      items = BBCodeProgress.parse_sig(sig)
      expect(items.length).to eq(0)
    end

    it "parses multiple items" do
      sig = "[progress=foo]1/42[/progress] [progress=bar]2/37[/progress]"
      items = BBCodeProgress.parse_sig(sig)
      expect(items.length).to eq(2)
      expect_progress(items["foo"], "foo", 1, 42)
      expect_progress(items["bar"], "bar", 2, 37)
    end
  end

  context "updates progress" do
    before(:context) do
      @original_stderr = $stderr
      $stderr = File.open(File::NULL, "w")
    end

    before(:example) do
      @old_sig = "[progress=foo]1/42[/progress] [progress=bar]2/37[/progress]"
    end

    after(:context) do
      $stderr = @original_stderr
    end

    it "replaces value" do
      new_sig = BBCodeProgress.update(@old_sig, ["foo=3"])
      expect(new_sig).to eq("[progress=foo]3/42[/progress] [progress=bar]2/37[/progress]")
    end

    it "replaces max" do
      new_sig = BBCodeProgress.update(@old_sig, ["foo=/14"])
      expect(new_sig).to eq("[progress=foo]1/14[/progress] [progress=bar]2/37[/progress]")
    end

    it "replaces value and max" do
      new_sig = BBCodeProgress.update(@old_sig, ["foo=3/14"])
      expect(new_sig).to eq("[progress=foo]3/14[/progress] [progress=bar]2/37[/progress]")
    end

    it "handles update with fractional value" do
      new_sig = BBCodeProgress.update(@old_sig, ["foo=.3"])
      expect(new_sig).to eq("[progress=foo]30/4200[/progress] [progress=bar]2/37[/progress]")
    end

    it "handles update with fractional value and int max" do
      new_sig = BBCodeProgress.update(@old_sig, ["foo=.3/14"])
      expect(new_sig).to eq("[progress=foo]30/1400[/progress] [progress=bar]2/37[/progress]")
    end

    it "preserves leading part of signature" do
      lead = "leading line\nleading words"
      old_sig = "#{lead}#{@old_sig}"
      new_sig = BBCodeProgress.update(old_sig, ["foo=3/14"])
      expect(new_sig).to eq(
        "#{lead}[progress=foo]3/14[/progress] [progress=bar]2/37[/progress]"
      )
    end

    it "preserves trailing part of signature" do
      trail = "trailing line\ntrailing words"
      old_sig = "#{@old_sig}#{trail}"
      new_sig = BBCodeProgress.update(old_sig, ["foo=3/14"])
      expect(new_sig).to eq(
        "[progress=foo]3/14[/progress] [progress=bar]2/37[/progress]#{trail}"
      )
    end

    it "preserves leading & trailing parts of signature" do
      lead = "leading line\nleading words"
      trail = "trailing line\ntrailing words"
      old_sig = "#{lead}#{@old_sig}#{trail}"
      new_sig = BBCodeProgress.update(old_sig, ["foo=3/14"])
      expect(new_sig).to eq(
        "#{lead}[progress=foo]3/14[/progress] [progress=bar]2/37[/progress]#{trail}"
      )
    end

    it "ignores unknown items" do
      new_sig = BBCodeProgress.update(@old_sig, ["qux=7/9"])
      expect(new_sig).to eq(@old_sig)
    end

    it "warns when an item is not updated" do
      expect { BBCodeProgress.update(@old_sig, ["foo=3/14"]) }
          .to output(/WARNING: did not update 'bar'/).to_stderr
    end

    it "warns when an option does not match any items" do
      expect { BBCodeProgress.update(@old_sig, ["qux=7/9"]) }
          .to output(/WARNING: no such item 'qux', will not create one/).to_stderr
    end

    it "matches items case-insensitively" do
      new_sig = BBCodeProgress.update(@old_sig, ["FOO=3/14"])
      expect(new_sig).to eq("[progress=foo]3/14[/progress] [progress=bar]2/37[/progress]")
    end

    it "fails if max is somehow (via a bug) absent" do
      old_progress = { "foo" => BBCodeProgress.new("foo", 3, nil) }
      args_progress = BBCodeProgress.parse_args(["foo=3/14"])
      expect{ BBCodeProgress.update!(old_progress, args_progress) }
          .to raise_error("ERROR: all old_progress items must have @max set")
    end

    it "increments and/or decrements" do
      arg_values      = [ nil, "+1", "2", "-1" ]
      expected_values = [ nil,   2,   2,    0  ]
      arg_maxes       = [ nil, "+4", "5", "-6" ]
      expected_maxes  = [ nil,  46,   5,   36  ]

      arg_values.each_with_index do |value, v_ndx|
        arg_maxes.each_with_index do |max, m_ndx|
          # Don't test when BOTH are nil; that case is handled elsewhere.
          next if value.nil? and max.nil?

          arg = "foo="
          arg += value unless value.nil?
          arg += "/" if max
          arg += max unless max.nil?

          expected = "#{expected_values[v_ndx] || 1}/#{expected_maxes[m_ndx] || 42}"

          new_sig = BBCodeProgress.update(@old_sig, [arg])
          expect(new_sig).to eq(
            "[progress=foo]#{expected}[/progress] [progress=bar]2/37[/progress]"
          )
        end
      end
    end

  end
end
