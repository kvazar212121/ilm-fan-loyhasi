package security

import (
	"sync"
	"time"

	"github.com/muhriddinnorqulov/skeleton/src/auth/domain"
)

const (
	accountMaxFailures = 10
	ipMaxFailures      = 50
	failureWindow      = 15 * time.Minute
	trackedKeyCap      = 50_000
)

type failureWindowEntry struct {
	start time.Time
	count int
}

type RateThrottleImpl struct {
	mu       sync.Mutex
	failures map[string]*failureWindowEntry
	now      func() time.Time
}

// @inject
func NewRateThrottleImpl() domain.RateThrottle {
	return &RateThrottleImpl{
		failures: map[string]*failureWindowEntry{},
		now:      time.Now,
	}
}

func (t *RateThrottleImpl) Check(ip, account string) error {
	t.mu.Lock()
	defer t.mu.Unlock()
	if (account != "" && t.blocked("a:"+account, accountMaxFailures)) ||
		(ip != "" && t.blocked("i:"+ip, ipMaxFailures)) {
		return domain.ErrLoginLocked
	}
	return nil
}

func (t *RateThrottleImpl) Failure(ip, account string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if account != "" {
		t.add("a:" + account)
	}
	if ip != "" {
		t.add("i:" + ip)
	}
}

func (t *RateThrottleImpl) Success(_, account string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if account != "" {
		delete(t.failures, "a:"+account)
	}
}

func (t *RateThrottleImpl) blocked(key string, limit int) bool {
	w := t.failures[key]
	if w == nil {
		return false
	}
	if t.now().Sub(w.start) > failureWindow {
		delete(t.failures, key)
		return false
	}
	return w.count >= limit
}

func (t *RateThrottleImpl) add(key string) {
	now := t.now()
	w := t.failures[key]
	if w == nil || now.Sub(w.start) > failureWindow {
		if len(t.failures) >= trackedKeyCap {
			t.failures = map[string]*failureWindowEntry{}
		}
		w = &failureWindowEntry{start: now}
		t.failures[key] = w
	}
	w.count++
}
