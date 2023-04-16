import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ThankYouVerifyComponent } from './thank-you-verify.component';

describe('ThankYouVerifyComponent', () => {
  let component: ThankYouVerifyComponent;
  let fixture: ComponentFixture<ThankYouVerifyComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ThankYouVerifyComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ThankYouVerifyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
