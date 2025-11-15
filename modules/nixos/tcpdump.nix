{
  username,
  ...
}: {
  programs.tcpdump.enable = true;
  users.users.${username}.extraGroups = ["pcap"];
}
