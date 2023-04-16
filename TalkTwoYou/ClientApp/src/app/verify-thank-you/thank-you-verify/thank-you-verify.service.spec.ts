import { TestBed } from '@angular/core/testing';

import { ThankYouVerifyService } from './thank-you-verify.service';

describe('ThankYouVerifyService', () => {
  let service: ThankYouVerifyService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ThankYouVerifyService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
