import { TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { RouteGuardGuard } from './route-guard.guard';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
describe('RouteGuardGuard', () => {
  let guard: RouteGuardGuard;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)]
    });
    guard = TestBed.inject(RouteGuardGuard);
  });

  it('should be created', () => {
    expect(guard).toBeTruthy();
  });
});
