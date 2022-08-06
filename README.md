## recoverybox for histb
```
git add .
git commit -m "set some change by default"
git format-patch -s -1,2...

cat *.patch | patch -p1
```

