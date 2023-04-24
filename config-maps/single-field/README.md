# Mount single file
---

When you mount a ConfigMap like this:

```
containers:
- name: blahblah
  ...
  volumeMounts:
  - name: my-config
    mountPath: /var
volumes:
- name: my-config
  configMap:
   name: configuration
```

Each field in `configuration` will be a file in `/var`, and it will override all the files that were
in `/var` before.

Sometimes we want to add only one field as a file, witout removing all the files in the target directory.
See in this example how it's done
