#!/usr/bin/env python3

import filecmp
import re
import shutil

grub_cmdline_linux_matcher = re.compile('GRUB_CMDLINE_LINUX="(?P<options>.*)"')


with open('/etc/default/grub', 'r') as grub_in_file:
    with open('/tmp/grub', 'w') as grub_out_file:
        for grub_line in grub_in_file:
            grub_cmdline_linux_match = grub_cmdline_linux_matcher.match(grub_line)
            if grub_cmdline_linux_match:
                options = grub_cmdline_linux_match.groupdict()['options'].split()
                saved_options = []
                for option in options:
                    if '=' in option:
                        key, value = option.split('=')
                        if key not in ['audit', 'audit_backlog_limit']:
                            saved_options.append(option)
                    else:
                        saved_options.append(option)
                saved_options.append('audit=1')
                saved_options.append('audit_backlog_limit=8192')
                grub_cmdline_linux_value = " ".join(saved_options)
                print(f'GRUB_CMDLINE_LINUX="{grub_cmdline_linux_value}"', file = grub_out_file)

            else:
                print(grub_line.strip(), file = grub_out_file)


if not filecmp.cmp('/tmp/grub', '/etc/default/grub'):
    shutil.move('/tmp/grub', '/etc/default/grub')
    print('Updated')
else:
    print("No change")

