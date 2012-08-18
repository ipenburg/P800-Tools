; Create a pair of images that are optimized for display on the screen of a
; Sony-Ericsson P800 smartphone. These images use a fixed 4096 color palette
; and are 208 pixels wide with a 320 and a 144 pixels high version for the two
; modes of the flip. See Colors > Info Colorcube Analysis... for the number of
; colors in the results. We assume the image has all the other optimizations
; already manually done because this is the last optimization step.

(define (script-fu-image-convert-indexed-p800 img)
  (let*
    (
     (p800-dither-type	1) ; Floyd-Steinberg
     (p800-palette-type	0)
     (p800-palette-size 16) ; 4 bit
     (p800-alpha-dither 0)
     )
    (gimp-image-convert-indexed
      img p800-dither-type p800-palette-type
      p800-palette-size p800-alpha-dither 0 "")
    (gimp-image-convert-grayscale img)
    )
  )

(define (script-fu-file-png-save2-p800 img filename)
  (let*
    (
     (run-mode	1)
     (interlace	1)
     (compression	9)
     (bkgd	1)
     (gama	0)
     (offs	0)
     (phys	0)
     (time	0)
     (comment	0)
     (svtrans	0)
    )
    (file-png-save2
      run-mode
      img
      (car (gimp-image-get-active-layer img))
      filename
      filename
      interlace
      compression
      bkgd
      gama
      offs
      phys
      time
      comment
      svtrans
     )
    )
  )


(define (script-fu-optimize-for-p800 img drawable wallpaper screensaver)
  (let*
    (
     (run-mode	1	)
     (compose-type 	"RGB")
     (layers-mode	0)
     (p800-width	208)
     (p800-height	320)
     (p800-height-flip	144)
     (p800-interp	2)
     (p800-img 		(car (gimp-image-new p800-width p800-height RGB)))
     (p800-img-flip 	())
     (p800-channels	())
     )

    ; Make a working copy of the layer we're going to optimize
    (gimp-image-add-layer
      p800-img
      (car (gimp-layer-new-from-drawable drawable p800-img))
      -1)
    ; Scale the working copy
    (gimp-layer-scale-full
      (car (gimp-image-get-active-layer p800-img))
      p800-width p800-height 0 p800-interp)
    ; Flatten the working copy to prevent alpha channel issues
    (gimp-layer-flatten (car (gimp-image-get-active-layer p800-img)))

    ; Split the working copy into the 3 color channels (ignoring last item)
    (set! p800-channels (reverse (cdr (reverse (plug-in-decompose
						 run-mode p800-img
						 (car (gimp-image-get-active-layer p800-img))
						 compose-type layers-mode))))
      )

    ; Dither the color channels seperately
    (map script-fu-image-convert-indexed-p800 p800-channels)

    ; Put the dithered color channels back together again
    (set! p800-img (plug-in-compose
		     run-mode
		     (list-ref p800-channels 0)
		     drawable ; unused
		     (list-ref p800-channels 1)
		     (list-ref p800-channels 2)
		     (list-ref p800-channels 2) ; dummy
		     compose-type
		     ))
    (map gimp-image-delete p800-channels)

    ; Copy for the flip-closed version
    (set! p800-img-flip (gimp-image-duplicate (car p800-img)))
    (gimp-image-crop (car p800-img-flip) p800-width p800-height-flip 0 0)

    ; Save the two images
    (script-fu-file-png-save2-p800 (car p800-img) screensaver)
    (script-fu-file-png-save2-p800 (car p800-img-flip) wallpaper)

    ;(map gimp-display-new (list (car p800-img) (car p800-img-flip)))
    ;(gimp-displays-flush)
    )
  )

(script-fu-register "script-fu-optimize-for-p800"
		    "Sony-Ericsson P800..."
		    "Create a dithered image using a fixed 4096 color palette"
		    "Roland van Ipenburg <ipenburg@xs4all.nl>"
		    "Roland van Ipenburg"
		    "2010-01-20"
		    ""
		    SF-IMAGE	"Image" 0
		    SF-DRAWABLE	"Layer" 0
		    SF-VALUE	"Filename for wallpaper" "\"P800-wallpaper.png\""
		    SF-VALUE	"Filename for screensaver" "\"P800-screensaver.png\"")
(script-fu-menu-register
  "script-fu-optimize-for-p800"
    "<Image>/Image/Mode/Fixed Palette"
  )
