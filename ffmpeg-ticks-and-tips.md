# FFmpeg Tips and Tricks

## Resize images in half

Use the `scale` option where `iw` is the input width and `ih` is the input height, to resize in half you can use the
division `/` operator and a colon as a separator between the width and height operations: `iw/2:ih/2`.

```
ffmpeg -i _MG_5010-2.jpg -vf scale="iw/2:ih/2" _MG_5010-2_small.jpg
```

To resize a list of images:
```
find . -name '*jpg' -exec ffmpeg -i {} -vf scale="iw/2:ih/2" {}.png \;
```

I this example I changed the filename extension to `png` for simplicity.
