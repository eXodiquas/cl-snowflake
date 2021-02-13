;;;; snowflake.lisp
;;; generates a random snowflake with random walk.

(in-package #:snowflake)

;; width and height of the canvas, those are the only parameters you should change.
(defparameter *canvas-width* 500)
(defparameter *canvas-height* 500)

;; trivial-gamekits way of setting up all the graphics stuff.
(gamekit:defgame snowflake () ()
  (:viewport-width *canvas-width*)
  (:viewport-height *canvas-height*)
  (:viewport-title "Snowflake")) 

;; starts the graphics engine.
(defun start ()
  (setf *particle* nil)
  (setf *particles* '())
  (gamekit:start 'snowflake))

;; initial values to store the particles that build the snowflake.
(defparameter *particle* nil)
(defparameter *particles* '())

;; stops the generation if t.
(defparameter *paused* t)

(defmethod gamekit:post-initialize ((app snowflake))
  ;; binds the spacebar to pause/unpause.
  (gamekit:bind-button :space :pressed (lambda () (setf *paused* (not *paused*))))
  ;; instantiates the first particle.
  (setf *particle*
	(make-instance 'particle
		       :particle-position (gamekit:vec2
					   (floor *canvas-width* 2)
					   0))))

;; runs every frame.
(defmethod gamekit:act ((app snowflake))
  ;; only runs when unpaused.
  (when (not *paused*)
    ;; updates for as long as the particle needs to land. (mostly for speed up)
    (loop while (not (or
		      (finishedp *particle*)
		      (intersectsp *particle*)))
	  do
	     (update *particle*))
    ;; add particle to list of finished particles so it can be rendered later.
    (push *particle* *particles*)
    ;; creates a new particle.
    (setf *particle*
	  (make-instance 'particle
			 :particle-position (gamekit:vec2
					     (floor *canvas-width* 2)
					     (1- (random 2)))))))

;; draws the scene every frame.
(defmethod gamekit:draw ((app snowflake))
  (gamekit:translate-canvas (floor *canvas-width* 2) (floor *canvas-height* 2))
  (draw *particle*)
  (loop for p in *particles* do
    (draw p)))

;; defines the particle. it got a position and a radius.
(defclass particle ()
  ((particle-position
    :initarg :particle-position
    :initform (gamekit:vec2 0 0)
    :accessor particle-position)
   (particle-radius
    :initarg :particle-radius
    :initform 2
    :accessor particle-radius)))

;; walks the particle into the negative y direction. (random walk)
(defmethod update ((p particle))
  (decf (gamekit:x (particle-position p)))
  (incf (gamekit:y (particle-position p)) (- 3 (random 6.0))))

;; draws 12 circles. it draws the main circle, mirrors it on the x axis and draws those 2 circles every PI/3 radians.
(defmethod draw ((p particle))
  (gamekit:with-pushed-canvas ()
    (gamekit:rotate-canvas (/ PI 6))
    (dotimes (i 6)
      (gamekit:with-pushed-canvas ()
	(gamekit:rotate-canvas (* i (/ PI 3)))
	(gamekit:draw-circle
	 (particle-position p)
	 (particle-radius p)
	 :fill-paint (gamekit:vec4 0 0 0 1))
	(let ((mirror-pos (gamekit:vec2
			   (gamekit:x (particle-position p))
			   (* -1 (gamekit:y (particle-position p))))))
	  (gamekit:draw-circle
	   mirror-pos
	   (particle-radius p)
	   :fill-paint (gamekit:vec4 0 0 0 1)))))))

;; checks if the particle is on x equals 0 or smaller.
(defmethod finishedp ((p particle))
  (<= (gamekit:x (particle-position p)) 0))

;; checks if the current particle intersects any previous particle.
(defmethod intersectsp ((p particle))
  (not (loop for snow in *particles*
	     always (>
		     (distance (particle-position p) (particle-position snow))
		     (* 2 (particle-radius p))))))

;; calculates the euclidean disctance between two points.
(defun distance (v1 v2)
  (let ((a (- (gamekit:x v1) (gamekit:x v2)))
	(b (- (gamekit:y v1) (gamekit:y v2))))
    (sqrt (+ (* a a) (* b b))))) 
