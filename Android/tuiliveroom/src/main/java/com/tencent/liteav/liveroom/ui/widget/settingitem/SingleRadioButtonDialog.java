package com.tencent.liteav.liveroom.ui.widget.settingitem;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.tencent.liteav.liveroom.R;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.List;

public class SingleRadioButtonDialog extends BottomSheetDialog {
    private Context          mContext;

    private RadioGroup       mRadioGroup;
    private TextView         mTitle;

    private List<String>     mDataArray;
    private OnSelectListener mListener;
    private int              mSelectPosition;

    public SingleRadioButtonDialog(Context context, List<String> dataArray) {
        super(context, R.style.BaseFragmentDialogTheme);
        mContext = context;
        mDataArray = dataArray;
        setContentView(R.layout.trtcliveroom_meeting_dialog_single_radio_button);
        initView();
    }

    private void initView() {
        mRadioGroup = findViewById(R.id.radio_group);
        mTitle = findViewById(R.id.tv_title);
        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        if (mDataArray != null) {
            for (int i = 0; i < mDataArray.size(); i++) {
                RadioButton radioButton = createRadioButton(mDataArray.get(i));
                radioButton.setId(i);
                if (i == mSelectPosition) {
                    radioButton.setChecked(true);
                }
                mRadioGroup.addView(radioButton);
            }
        }
        mRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                RadioButton radioButton = (RadioButton) findViewById(checkedId);
                String selectText = radioButton.getText().toString();
                mSelectPosition = checkedId;
                if (mListener != null) {
                    mListener.onSelect(checkedId, selectText);
                }
                dismiss();
            }
        });
        ((View)mTitle.getParent().getParent()).setBackgroundColor(Color.TRANSPARENT);
    }

    public void setTitle(String text) {
        mTitle.setText(text);
    }

    private RadioButton createRadioButton(String text) {
        RadioButton radioButton = new RadioButton(mContext);
        radioButton.setPadding(ScreenUtil.dip2px(20), ScreenUtil.dip2px(12),
                ScreenUtil.dip2px(20), ScreenUtil.dip2px(12));
        radioButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        radioButton.setTextColor(mContext.getResources().getColor(R.color.trtcliveroom_color_second_text));
        radioButton.setText(text);
        radioButton.setButtonDrawable(null);
        setStyle(radioButton);
        return radioButton;
    }

    private void setStyle(RadioButton rb) {
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        Drawable drawable = mContext.getResources().getDrawable(R.drawable.trtcliveroom_bg_rb_icon_selector);
        drawable.setBounds(0, 0, ScreenUtil.dip2px(24), ScreenUtil.dip2px(24));
        rb.setCompoundDrawables(null, null, drawable, null);
        rb.setLayoutParams(layoutParams);
    }

    public void setSelection(final int position) {
        mSelectPosition = position;
        if (null == mRadioGroup) {
            return;
        }
        for (int i = 0; i < mRadioGroup.getChildCount(); i++) {
            if (mRadioGroup.getChildAt(i) instanceof RadioButton) {
                final int id = mRadioGroup.getChildAt(i).getId();
                if (id == position) {
                    ((RadioButton) mRadioGroup.getChildAt(i)).setChecked(true);
                }
            }
        }
    }

    public int getSelectedItemPosition() {
        return mSelectPosition;
    }

    public void setSelectListener(OnSelectListener listener) {
        mListener = listener;
    }

    public interface OnSelectListener {
        void onSelect(int position, String text);
    }
}
