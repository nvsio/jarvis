(function() {
          var COLORS, FRICTION, GRAVITY, MAX_FORCE, NUM_PARTICLES, Particle, TAIL_LENGTH;

          NUM_PARTICLES = 260;

          TAIL_LENGTH = 8;

          MAX_FORCE = 12;

          FRICTION = 0.48;

          GRAVITY = 9.81;

          COLORS = ['#fff'];

          Particle = (function() {
            function Particle(x, y, mass) {
              this.x = x != null ? x : 0.0;
              this.y = y != null ? y : 0.0;
              this.mass = mass != null ? mass : 1.0;
              this.tail = [];
              this.radius = this.mass * 0.25;
              this.charge = random([-1, 1]);
              this.color = random(COLORS);
              this.fx = this.fy = 0.0;
              this.vx = this.vy = 0.0;
            }

            return Particle;

          })();

          Sketch.create({
            particles: [],
            interval: 3,
            setup: function() {
              var i, m, x, y, _i, _results;
              _results = [];
              for (i = _i = 0; _i <= NUM_PARTICLES; i = _i += 1) {
                x = random(this.width);
                y = random(this.height);
                m = random(8.0, 14.0);
                _results.push(this.particles.push(new Particle(x, y, m)));
              }
              return _results;
            },
            draw: function() {
              var a, b, dSq, dst, dx, dy, f, fx, fy, i, j, len, p, rad, _i, _j, _k, _len, _ref, _ref1, _results;
              this.lineCap = this.lineJoin = 'round';
              _results = [];
              for (i = _i = 0; _i <= NUM_PARTICLES; i = _i += 1) {
                a = this.particles[i];
                if (random() < 0.5) {
                  a.charge = -a.charge;
                }
                for (j = _j = _ref = i + 1; _j <= NUM_PARTICLES; j = _j += 1) {
                  b = this.particles[j];
                  dx = b.x - a.x;
                  dy = b.y - a.y;
                  dst = sqrt(dSq = (dx * dx + dy * dy) + 0.1);
                  rad = a.radius + b.radius;
                  if (dst >= rad) {
                    len = 1.0 / dst;
                    fx = dx * len;
                    fy = dy * len;
                    f = min(MAX_FORCE, (GRAVITY * a.mass * b.mass) / dSq);
                    a.fx += f * fx * b.charge;
                    a.fy += f * fy * b.charge;
                    b.fx += -f * fx * a.charge;
                    b.fy += -f * fy * a.charge;
                  }
                }
                a.vx += a.fx;
                a.vy += a.fy;
                a.vx *= FRICTION;
                a.vy *= FRICTION;
                a.tail.unshift({
                  x: a.x,
                  y: a.y
                });
                if (a.tail.length > TAIL_LENGTH) {
                  a.tail.pop();
                }
                a.x += a.vx;
                a.y += a.vy;
                a.fx = a.fy = 0.0;
                if (a.x > this.width + a.radius) {
                  a.x = -a.radius;
                  a.tail = [];
                } else if (a.x < -a.radius) {
                  a.x = this.width + a.radius;
                  a.tail = [];
                }
                if (a.y > this.height + a.radius) {
                  a.y = -a.radius;
                  a.tail = [];
                } else if (a.y < -a.radius) {
                  a.y = this.height + a.radius;
                  a.tail = [];
                }
                this.strokeStyle = a.color;
                this.lineWidth = a.radius * 0.1;
                this.beginPath();
                this.moveTo(a.x, a.y);
                _ref1 = a.tail;
                for (_k = 0, _len = _ref1.length; _k < _len; _k++) {
                  p = _ref1[_k];
                  this.lineTo(p.x, p.y);
                }
                _results.push(this.stroke());
              }
              return _results;
            }
          });

        }).call(this);