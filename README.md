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
      "echo $@"
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
