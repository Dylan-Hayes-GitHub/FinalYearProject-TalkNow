import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StartNewConversationPopUpComponent } from './start-new-conversation-pop-up.component';

describe('StartNewConversationPopUpComponent', () => {
  let component: StartNewConversationPopUpComponent;
  let fixture: ComponentFixture<StartNewConversationPopUpComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ StartNewConversationPopUpComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StartNewConversationPopUpComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
