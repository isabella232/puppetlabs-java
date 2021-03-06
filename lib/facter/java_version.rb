# frozen_string_literal: true

# Fact: java_version
#
# Purpose: get full java version string
#
# Resolution:
#   Tests for presence of java, returns nil if not present
#   returns output of "java -version" and splits on '"'
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:java_version) do
  # the OS-specific overrides need to be able to return nil,
  # to indicate "no java available". Usually returning nil
  # would mean that facter falls back to a lower priority
  # resolution, which would then trigger MODULES-2637. To
  # avoid that, we confine the "default" here to not run
  # on those OS.
  # Additionally, facter versions prior to 2.0.1 only support
  # positive matches, so this needs to be done manually in setcode.
  setcode do
    unless ['darwin'].include? Facter.value(:kernel).downcase
      version = nil
      if Facter::Util::Resolution.which('java')
        Facter::Util::Resolution.exec('java -Xmx12m -version 2>&1').lines.each { |line| version = Regexp.last_match(1) if %r{^.+ version \"(.+)\"} =~ line }
      end
      version
    end
  end
end

Facter.add(:java_version) do
  confine kernel: 'Darwin'
  has_weight 100
  setcode do
    unless Facter::Util::Resolution.exec('/usr/libexec/java_home --failfast 2>&1').include?('Unable to find any JVMs matching version')
      version = nil
      Facter::Util::Resolution.exec('java -Xmx12m -version 2>&1').lines.each { |line| version = Regexp.last_match(1) if %r{^.+ version \"(.+)\"} =~ line }
      version
    end
  end
end
