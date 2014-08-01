cb-libvirt
==========


Example hook data_bag
================
```
{
  "id": "reject_default_route",
  "type": "domain",
  "content": {
    [
      "#!/bin/sh",
      "echo $@",
      "network_up() {",
      "  echo up",
      "}",
      "network_down() {",
      "  echo down",
      "}",
      "name=$1",
      "task=$2",
      "xml=/tmp/libvirt.$0.$name.$$",
      "trap 'rm -f $xml;' EXIT SIGINT SIGQUIT",
      "cat - > $xml",
      "case $task in",
      "started)",
      ";;",
      "release)",
      ";;",
      "*)",
      "  echo 'qemu hook called with unexpected options ' $@ >&2",
      ";;",
      "esac"
    ]
  }
}
```


Example lvm pool data_bag
================
```
{
  "id": "default",
  "content": [
    "<pool type='logical'>",
    "  <name><%= @name %></name>",
    "  <source>",
    "<% @devices.each do |path| -%>",
    "    <device path='<%= path %>'/>",
    "<% end -%>",
    "    <format type='lvm2'/>",
    "  </source>",
    "  <target>",
    "    <path><%= @path %></path>",
    "  </target>",
    "</pool>"
  ]
}
```
