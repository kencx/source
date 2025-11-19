+++
title = "How to use a FUSE-mounted directory as a Docker volume"
date = "2025-11-20"
updated = "2025-11-20"

[taxonomies]
tags = ["fuse", "docker"]
+++

We need to allow the Docker user `docker` to access the FUSE-mounted filesystem
with the `allow_other` or `allow_root` mount options

{% quote(source="[fuse(8)](https://man.archlinux.org/man/mount.fuse.8.en)") %}
allow_other


This option overrides the security measure restricting file access to the user
mounting the filesystem. So all users (including root) can access the files.
This option is by default only allowed to root, but this restriction can be
removed with a configuration option described in the previous section.
{% end %}

However, to specify these mount options, we must set the following configuration
line in `/etc/fuse.conf`:

```conf
user_allow_other
```

With this, we can mount the FUSE filesystem with `-o allow_root` or `-o allow_other`:

```bash
fusermount -o allow_other [MOUNTPOINT]
```

Finally, mount a directory in the FUSE filesystem as a Docker volume.

## References
- [fuse(8)](https://man.archlinux.org/man/mount.fuse.8.en)
- [Using a FUSE-mounted directory as a docker volume](https://serverfault.com/questions/943979/using-a-fuse-mounted-directory-as-a-docker-volume)
